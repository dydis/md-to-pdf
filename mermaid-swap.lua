function CodeBlock(block)
    if block.classes:includes('mermaid') then
        local img_path = block.attributes['image']
        if img_path then
            return pandoc.Para({pandoc.Image({}, img_path, "")})
        else
            return {}
        end
    end
end