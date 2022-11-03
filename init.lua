-- mod-version:3 -- lite-xl 2.1
-- Author : Juliardi
-- Email : ardi93@gmail.com
-- Github : github.com/juliardi

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local style = require "core.style"
local view = require "plugins.treeview"

local menu = view.contextmenu

-- checks whether a file or directory exists
local function is_object_exist(path)
  local stat = system.get_file_info(path)
  if not stat or (stat.type ~= "file" and stat.type ~= "dir") then
    return false
  end
  return true
end

-- checks whether an object is a directory
local function is_dir(path)
  local file_info = system.get_file_info(path)
  return file_info.type == "dir"
end

-- moves object (file or directory) to another path
local function move_object(old_abs_filename, new_abs_filename) 
  local res, err = os.rename(old_abs_filename, new_abs_filename)
  if res then -- successfully renamed
    core.log("Moved \"%s\" to \"%s\"", old_abs_filename, new_abs_filename)
  else
    core.error("Error while moving \"%s\" to \"%s\": %s", old_abs_filename, new_abs_filename, err)
  end
end

command.add(
  function()
    return view.hovered_item ~= nil
      and is_dir(view.hovered_item.abs_filename) ~= true
  end, {
  ["treeview:duplicate-file"] = function()
    local old_filename = view.hovered_item.abs_filename
    core.command_view:set_text(view.hovered_item.filename)
    core.command_view:enter("Filename", function(filename)
      local new_filename = core.project_dir .. PATHSEP .. filename

      if (is_object_exist(new_filename)) then
        core.error("Unable to duplicate file : %s to %s. Duplicate name exists.", old_filename, new_filename)
        return
      end

      local old_file = io.open(old_filename, "r")
      local old_file_content = old_file:read("a")
      old_file:close()

      local file = io.open(new_filename, "a+")
      file:write(old_file_content)
      file:close()

      core.root_view:open_doc(core.open_doc(new_filename))
      core.log("Duplicate %s to %s", old_filename, new_filename)
    end, common.path_suggest)
  end
  })

command.add(
  function()
    return view.hovered_item ~= nil
      and view.hovered_item.abs_filename ~= core.project_dir
  end, {
  ["treeview:move-to"] = function()
    local old_abs_filename = view.hovered_item.abs_filename
    core.command_view:set_text(view.hovered_item.abs_filename)
    core.command_view:enter("Move to",
      function(new_abs_filename)
        if (is_object_exist(new_abs_filename)) then
          -- Ask before rewriting
          local opt = {
            { font = style.font, text = "Yes", default_yes = true },
            { font = style.font, text = "No" , default_no = true }
          }
          core.nag_view:show(
            string.format("Rewrite existing file?"),
            string.format(
              "File %s already exist. Rewrite file?",
              new_abs_filename
            ),
            opt,
            function(item)
              if item.text == "Yes" then
                os.remove(new_abs_filename)
                move_object(old_abs_filename, new_abs_filename)
              end
            end
          )
        else
          move_object(old_abs_filename, new_abs_filename)
        end
      end
    )
  end
  })

menu:register(
  function()
    return view.hovered_item
      and (is_dir(view.hovered_item.abs_filename) ~= true
      or view.hovered_item.abs_filename ~= core.project_dir)
  end,
  {
    menu.DIVIDER,
  }
)

-- Menu 'Duplicate File..' only shown when an object is selected
-- and the object is a file
menu:register(
  function()
    return view.hovered_item
      and is_dir(view.hovered_item.abs_filename) ~= true
  end,
  {
    { text = "Duplicate File..", command = "treeview:duplicate-file" },
  }
)

-- Menu 'Move To..' only shown when an object is selected
-- and the object is not the project directory
menu:register(
  function()
    return view.hovered_item
      and view.hovered_item.abs_filename ~= core.project_dir
  end,
  {
    { text = "Move To..", command = "treeview:move-to" },
  }
)

return view
