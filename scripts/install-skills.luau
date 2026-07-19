const fs = require("@std/fs")
const io = require("@std/io")
const path = require("@std/path")
const process = require("@lute/process")

const function fail(message: string): never
	print(`error: {message}`)
	process.exit(1)
	error("process.exit returned unexpectedly", 0)
end

const USAGE_TEXT = [[
Usage:
  lute run scripts/install-skills.luau --dest <directory> [skill ...]
  lute run scripts/install-skills.luau --dest <directory> --all
  lute run scripts/install-skills.luau --project <directory> [skill ...]
  lute run scripts/install-skills.luau --list

When no skill names are given, an interactive checklist is shown.
Existing skill files are overwritten when selected for an update.
]]

const function usage()
	print(USAGE_TEXT)
end

const function copyDirectory(source, destination)
	if not fs.exists(destination) then
		fs.createDirectory(destination, { makeParents = true })
	elseif fs.type(destination) ~= "dir" then
		fail(`cannot merge into non-directory path: {path.format(destination)}`)
	end

	for _, entry in fs.listDirectory(source) do
		const sourceEntry = path.join(source, entry.name)
		const destinationEntry = path.join(destination, entry.name)

		if entry.type == "dir" then
			copyDirectory(sourceEntry, destinationEntry)
		elseif entry.type == "file" then
			fs.copy(sourceEntry, destinationEntry)
		else
			fail(`unsupported file type at {path.format(sourceEntry)}: {entry.type}`)
		end
	end
end

const function validateMerge(source, destination)
	if not fs.exists(destination) then
		return
	end

	if fs.type(source) ~= "dir" or fs.type(destination) ~= "dir" then
		fail(`cannot merge duplicate path: {path.format(destination)}`)
	end

	for _, entry in fs.listDirectory(source) do
		validateMerge(path.join(source, entry.name), path.join(destination, entry.name))
	end
end

const function validateUpdate(source, destination)
	if not fs.exists(destination) then
		return
	end

	const sourceType = fs.type(source)
	const destinationType = fs.type(destination)
	if sourceType ~= destinationType then
		fail(`cannot update path with a different file type: {path.format(destination)}`)
	elseif sourceType == "dir" then
		for _, entry in fs.listDirectory(source) do
			validateUpdate(path.join(source, entry.name), path.join(destination, entry.name))
		end
	elseif sourceType ~= "file" then
		fail(`unsupported file type at {path.format(source)}: {sourceType}`)
	end
end

const scriptPath = process.args[1]
if scriptPath == nil then
	fail("could not determine the script path")
end

const repositoryRoot = path.resolve(path.dirname(scriptPath), "..")
const skillsRoot = path.join(repositoryRoot, "skills")
const docsRoot = path.join(repositoryRoot, "docs")

const function availableSkills(): { string }
	const names = {}

	for _, entry in fs.listDirectory(skillsRoot) do
		if entry.type == "dir" and fs.exists(path.join(skillsRoot, entry.name, "SKILL.md")) then
			table.insert(names, entry.name)
		end
	end

	table.sort(names)
	return names
end

const function skillDescription(name: string): string
	const skillFile = fs.readFileToString(path.join(skillsRoot, name, "SKILL.md"))
	return string.match(skillFile, "\ndescription:%s*([^\r\n]+)") or ""
end

const function selectSkillsWithNumbers(installable: { string }, labels: { string }): { string }
	io.write("Select skills to install:\n")
	for index, label in labels do
		io.write(`[ ] {index}. {label}\n`)
	end

	const answer = string.gsub(io.input("Enter comma-separated numbers (for example, 1,3,5 / all, or Enter to cancel): "), "%s+", "")
	if answer == "" then
		return {}
	elseif string.lower(answer) == "all" then
		return installable
	end

	const selected = {}
	const selectedIndexes = {}
	for token in string.gmatch(answer, "[^,]+") do
		const selectedIndex = tonumber(token)
		if selectedIndex == nil or selectedIndex % 1 ~= 0 or installable[selectedIndex] == nil then
			fail(`invalid skill number: {token}`)
		elseif not selectedIndexes[selectedIndex] then
			selectedIndexes[selectedIndex] = true
			table.insert(selected, installable[selectedIndex])
		end
	end

	return selected
end

const function selectSkillsWithFzf(installable: { string }, labels: { string }): { string }?
	const available, versionResult = pcall(function()
		return process.run({ "fzf", "--version" })
	end)
	if not available or not versionResult.ok then
		return nil
	end

	local temporaryRoot = process.env.TMPDIR or process.env.TEMP or process.env.TMP
	if temporaryRoot == nil or not fs.exists(temporaryRoot) or fs.type(temporaryRoot) ~= "dir" then
		temporaryRoot = repositoryRoot
	end

	const prefix = `install-skills-{math.random(1, 1_000_000_000)}`
	const inputName = `{prefix}.in`
	const outputName = `{prefix}.out`
	const inputPath = path.join(temporaryRoot, inputName)
	const outputPath = path.join(temporaryRoot, outputName)
	fs.writeStringToFile(inputPath, `{table.concat(labels, "\n")}\n`)
	if fs.exists(outputPath) then
		fs.remove(outputPath)
	end

	const fzfEnvironment = {}
	for name, value in process.env do
		fzfEnvironment[name] = value
	end

	const interfaceOptions = [[--multi --layout=reverse --border --info=inline --marker="✓ " --pointer="> " --prompt="Search > " --header="Select skills | Up/Down: move | Space: toggle | Enter: install" --bind=space:toggle+down]]
	const inheritedOptions = fzfEnvironment.FZF_DEFAULT_OPTS
	fzfEnvironment.FZF_DEFAULT_OPTS = if inheritedOptions == nil or inheritedOptions == ""
		then interfaceOptions
		else `{inheritedOptions} {interfaceOptions}`

	const ran, result = pcall(function()
		return process.system(
			`fzf < {inputName} > {outputName}`,
			{ cwd = path.format(temporaryRoot), stdio = "inherit", env = fzfEnvironment }
		)
	end)

	fs.remove(inputPath)
	if not ran or (not result.ok and result.exitcode ~= 1 and result.exitcode ~= 130) then
		if fs.exists(outputPath) then
			fs.remove(outputPath)
		end
		return nil
	end

	const output = if fs.exists(outputPath) then fs.readFileToString(outputPath) else ""
	if fs.exists(outputPath) then
		fs.remove(outputPath)
	end

	const namesByLabel = {}
	for index, label in labels do
		namesByLabel[label] = installable[index]
	end

	const selected = {}
	for label in string.gmatch(output, "[^\r\n]+") do
		const name = namesByLabel[label]
		if name == nil then
			return nil
		end
		table.insert(selected, name)
	end

	return selected
end

const function selectSkills(available: { string }, includeDescriptions: boolean): { string }
	const installable = {}
	const labels = {}

	for _, name in available do
		table.insert(installable, name)
		const label = if includeDescriptions then `{name} — {skillDescription(name)}` else name
		table.insert(labels, label)
	end

	if #installable == 0 then
		io.write("There are no skills available.\n")
		return {}
	end

	const fzfSelection = selectSkillsWithFzf(installable, labels)
	if fzfSelection ~= nil then
		return fzfSelection
	end

	return selectSkillsWithNumbers(installable, labels)
end

local destinationArgument: string? = nil
local projectArgument: string? = nil
local selectedSkills: { string } = {}
local listOnly = false
local installAll = false
local index = 2

while index <= #process.args do
	const argument = process.args[index]

	if argument == "--dest" then
		if destinationArgument ~= nil then
			fail("--dest may only be specified once")
		end

		index += 1
		destinationArgument = process.args[index]
		if destinationArgument == nil then
			fail("--dest requires a directory")
		end
	elseif argument == "--project" then
		if projectArgument ~= nil then
			fail("--project may only be specified once")
		end

		index += 1
		projectArgument = process.args[index]
		if projectArgument == nil then
			fail("--project requires a directory")
		end
	elseif argument == "--list" then
		listOnly = true
	elseif argument == "--all" then
		installAll = true
	elseif argument == "--help" or argument == "-h" then
		usage()
		process.exit(0)
	elseif string.sub(argument, 1, 1) == "-" then
		fail(`unknown option: {argument}`)
	else
		table.insert(selectedSkills, argument)
	end

	index += 1
end

const available = availableSkills()

if listOnly then
	if destinationArgument ~= nil or projectArgument ~= nil or #selectedSkills > 0 or installAll then
		fail("--list cannot be combined with an installation")
	end

	for _, name in available do
		print(name)
	end
	process.exit(0)
end

if destinationArgument ~= nil and projectArgument ~= nil then
	fail("--dest and --project cannot be combined")
elseif destinationArgument == nil and projectArgument == nil then
	usage()
	fail("--dest or --project is required")
end

if installAll and #selectedSkills > 0 then
	fail("--all cannot be combined with skill names")
end

const availableSet = {}
for _, name in available do
	availableSet[name] = true
end

local destinationRoot
if projectArgument ~= nil then
	const projectRoot = path.resolve(projectArgument)
	if not fs.exists(projectRoot) or fs.type(projectRoot) ~= "dir" then
		fail(`project directory does not exist: {path.format(projectRoot)}`)
	end

	destinationRoot = path.join(projectRoot, ".agents", "skills")
else
	destinationRoot = path.resolve(destinationArgument :: string)
end

const selectedSet = {}
const existingSkills = {}

if #selectedSkills == 0 then
	if installAll then
		selectedSkills = available
	else
		selectedSkills = selectSkills(available, projectArgument == nil)
	end
end

if #selectedSkills == 0 then
	print("No skills were installed.")
	process.exit(0)
end

for _, name in selectedSkills do
	if selectedSet[name] then
		fail(`skill was selected more than once: {name}`)
	elseif availableSet[name] ~= true then
		fail(`unknown skill: {name}`)
	end

	selectedSet[name] = true

	const sourceSkill = path.join(skillsRoot, name)
	const sourceDocs = path.join(docsRoot, name)
	const destinationSkill = path.join(destinationRoot, name)

	if fs.exists(destinationSkill) then
		if fs.type(destinationSkill) ~= "dir" then
			fail(`destination skill is not a directory: {path.format(destinationSkill)}`)
		end
		existingSkills[name] = true
	end

	validateUpdate(sourceSkill, destinationSkill)
	if fs.exists(sourceDocs) then
		validateMerge(sourceDocs, path.join(sourceSkill, "references"))
		validateUpdate(sourceDocs, path.join(destinationSkill, "references"))
	end
end

fs.createDirectory(destinationRoot, { makeParents = true })
print(`Installing {#selectedSkills} skill(s) -> {path.format(destinationRoot)}`)

for _, name in selectedSkills do
	const sourceSkill = path.join(skillsRoot, name)
	const sourceDocs = path.join(docsRoot, name)
	const destinationSkill = path.join(destinationRoot, name)

	copyDirectory(sourceSkill, destinationSkill)

	if fs.exists(sourceDocs) then
		copyDirectory(sourceDocs, path.join(destinationSkill, "references"))
	end

	const action = if existingSkills[name] then "updated" else "installed"
	print(`{action} {name} -> {path.format(destinationSkill)}`)
end
