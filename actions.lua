
local core = require "core"
local common = require "core.common"
local style = require "core.style"
local view = require "plugins.treeview"
local fsutils = require "plugins.treeview-menu-extender.fsutils"

local actions = {}

function actions.copy_to()
  local old_filename = view.hovered_item.abs_filename
  core.command_view:set_text(view.hovered_item.filename)
  core.command_view:enter("Filename", function(filename)
    local new_filename = core.project_dir .. PATHSEP .. filename

    if (fsutils.is_object_exist(new_filename)) then
      core.error("Unable to copy file : %s to %s. Duplicate name exists.", old_filename, new_filename)
      return
    end

    local old_file = io.open(old_filename, "r")
    local old_file_content = ''
    if (old_file ~= nil) then
      old_file_content = old_file:read("a")
      old_file:close()
    end

    local file = io.open(new_filename, "a+")
    if (file ~= nil) then
      file:write(old_file_content)
      file:close()
    end

    core.root_view:open_doc(core.open_doc(new_filename))
    core.log("Copying %s to %s", old_filename, new_filename)
  end, common.path_suggest)
end

function actions.move_to()
    local old_abs_filename = view.hovered_item.abs_filename
    core.command_view:set_text(view.hovered_item.abs_filename)
    core.command_view:enter("Move to",
      function(new_abs_filename)
        if (fsutils.is_object_exist(new_abs_filename)) then
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
                fsutils.move_object(old_abs_filename, new_abs_filename)
              end
            end
          )
        else
          fsutils.move_object(old_abs_filename, new_abs_filename)
        end
      end
    )
  end

return actions
