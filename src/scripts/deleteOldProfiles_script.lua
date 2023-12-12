function deleteOldProfiles(keepdays_arg, delete_folder)
  --[[
  Deletes old profiles/maps/modules in the "current"/"map"/"moduleBackups" folders of the Mudlet home directory.
  The following files are NOT deleted:
  - Files newer than the amount of days specified as an argument to deleteOldProfiles(), or 31 days if not specified.
  - One file for every month before that. Specifically: The first available file of every month prior to this.
  Setting the second argument to true will delete maps instead of profiles. (e.g. deleteOldProfiles(10, true))
  --]]

  -- Ensure correct value is passed for second argument
  assert(type(delete_folder) == "string", "Wrong type for delete_folder; expected string, got " .. type(delete_folder))
  assert(table.contains({"profiles", "maps", "modules"}, delete_folder), "delete_folder must be profiles, maps or modules")

  local keepdays = tonumber(keepdays_arg) or 31
  local profile_table = {}
  local used_last_mod_months = {}
  local slash = (string.char(getMudletHomeDir():byte()) == "/") and "/" or "\\"
  local delnum = 0

  local to_folder = {
    profiles = "current",
    maps = "map",
  }

  local dirpath = delete_folder == "modules"
    and getMudletHomeDir()..slash..".."..slash..".."..slash.."moduleBackups"
    or getMudletHomeDir()..slash..to_folder[delete_folder]

  -- Traverse the profiles folder and create a table of files:
  for filename in lfs.dir(dirpath) do
    if filename~="." and filename~=".." then
      profile_table[#profile_table+1] = {
        name = filename,
        last_mod = lfs.attributes(dirpath..slash..filename, "modification")
      }
    end
  end

  -- Sort the table according to last modification date from old to new:
  table.sort(profile_table, function (a,b) return a.last_mod < b.last_mod end)

  echo(string.format(
    "\nDeleting old %s. Files newer than %d days and one for every month before that will be kept.",
    delete_folder,
    keepdays
  ))

  for i, v in ipairs(profile_table) do
    local days = math.floor(os.difftime(os.time(), v.last_mod) / 86400)
    local last_mod_month = os.date("%Y/%m", v.last_mod)
    if days > keepdays then
      -- For profiles older than X days, check if we already kept a table for this month:
      if not table.contains(used_last_mod_months, last_mod_month) then
        -- If not, do nothing and mark this month as "kept".
        used_last_mod_months[#used_last_mod_months+1] = last_mod_month
      else
        -- Otherwise remove the file:
        local success, errorstring = os.remove(dirpath..slash..v.name)
        if success then
          delnum = delnum + 1
        else
          cecho("\n<red>ERROR: "..errorstring)
        end
      end
    end
  end

  echo(string.format("\nDeletion complete. %d/%d files were removed successfully.", delnum, #profile_table))
end
