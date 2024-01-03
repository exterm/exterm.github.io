-- Link headers to themselves

function Header (header)
  -- Create a new link that points to the header ID
  local link = pandoc.Link(header.content, '#' .. header.identifier)

  -- Replace the header content with this link
  header.content = { link }
  return header
end
