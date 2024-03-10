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
      <h1>Philip Mueller, Software Consultant</h1>
      <section>
        <h2>Services</h2>
        <p>I have extensive experience wrangling large scale systems in and around software. <b>Experience that you can benefit from.</b></p>

        <p><a href=pages/services>Learn more about the services I offer.</a></p>
      </section>

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
