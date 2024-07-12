<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>$title$</title>
    <link rel="stylesheet" href="main.css?ts=$timestamp$">
    <link rel="alternate" type="application/rss+xml" title="$title$ RSS" href="rss.xml">
    <link rel="canonical" href="$canonical$" />
  </head>
  <body>
    ${header.tpl()}

    <main>
      <section>
        <h2>Blog Posts</h2>
        <nav>
          $body$
        </nav>
      </section>
    </main>

    ${footer.tpl()}

  </body>
</html>
