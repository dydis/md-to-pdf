-- callout.lua
-- Converts GitHub callouts to LaTeX tcolorboxes for PDF output

function BlockQuote(el)
  local p = el.content[1]
  if p and p.t == "Para" then
    local first_element = p.content[1]
    
    if first_element and first_element.t == "Str" then
      local callout_type = first_element.text:match("^%[%!(%a+)%]$")
      
      if callout_type then
        -- Remove the [!TYPE] tag and the space right after it
        table.remove(p.content, 1)
        if p.content[1] and p.content[1].t == "Space" then
          table.remove(p.content, 1)
        end

        -- Check if we are outputting to PDF/LaTeX
        if FORMAT:match("latex") or FORMAT:match("pdf") then
          
          -- Default styling (for NOTE)
          local color = "blue"
          local icon = "info-circle"
          
          -- Adjust colors and icons for other callout types
          if callout_type == "WARNING" then 
            color = "orange"
            icon = "exclamation-triangle" 
          elseif callout_type == "IMPORTANT" or callout_type == "CAUTION" then 
            color = "red"
            icon = "exclamation-circle" 
          elseif callout_type == "TIP" or callout_type == "SUCCESS" then 
            color = "green"
            icon = "lightbulb" 
          end

          -- Build the LaTeX tcolorbox code
          local begin_tex = string.format(
            "\\begin{tcolorbox}[colback=%s!5!white, colframe=%s!75!black, title=\\faIcon{%s} \\textbf{%s}]", 
            color, color, icon, callout_type:upper()
          )
          local end_tex = "\\end{tcolorbox}"

          -- Wrap the original content inside the raw LaTeX blocks
          local result = { pandoc.RawBlock("latex", begin_tex) }
          for _, block in ipairs(el.content) do
            table.insert(result, block)
          end
          table.insert(result, pandoc.RawBlock("latex", end_tex))

          return result
        else
          -- Fallback for HTML/Text (just bold the text)
          table.insert(p.content, 1, pandoc.Strong({pandoc.Str(callout_type:upper() .. ": ")}))
          return el
        end
      end
    end
  end
end