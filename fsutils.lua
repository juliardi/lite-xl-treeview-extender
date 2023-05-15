
local core = require "core"

local fsutils = {}

-- checks whether a file or directory exists
function fsutils.is_object_exist(path)
  local stat = system.get_file_info(path)
  if not stat or (stat.type ~= "file" and stat.type ~= "dir") then
    return false
  end
  return true
end

-- checks whether an object is a directory
function fsutils.is_dir(path)
  local file_info = system.get_file_info(path)
  if (file_info ~= nil) then
    return file_info.type == "dir"
  end

  return false
end

-- moves object (file or directory) to another path
function fsutils.move_object(old_abs_filename, new_abs_filename)
  local res, err = os.rename(old_abs_filename, new_abs_filename)
  if res then -- successfully renamed
    core.log("Moved \"%s\" to \"%s\"", old_abs_filename, new_abs_filename)
  else
    core.error("Error while moving \"%s\" to \"%s\": %s", old_abs_filename, new_abs_filename, err)
  end
end

return fsutils
