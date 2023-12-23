---
title: "The mystery of Rails' `lib/` folder 📚"
---

_In Ruby on Rails applications, one of the directories that come out of the box is `lib/`. What is it for? How should it be used? And why should you care?_

![Railway tracks, a big Ruby, and a lot of books. Generated with GPT-4](assets/lib-is-for-libraries/lib-is-for-libraries.webp)

Used well, `lib/` is a very powerful tool to declutter an application, reduce cognitive load and improve developer productivity. But it's often not used well.

The official Rails guides say it's supposed to contain ["extended modules for your application"](https://guides.rubyonrails.org/v7.1/getting_started.html#creating-the-blog-application). What does that even mean? I don't think that's a useful definition.

Another idea that I've heard often is that the actual application should live in `lib/`. The earliest source I could find is [a 2011 blog post](http://blog.firsthand.ca/2011/10/rails-is-not-your-application.html) by Corey Haines:

> Rails is not your application. It might be your views and data source, but it’s not your application. Put your app in a Gem or under `lib/`.

I'm sorry to be the bearer of bad news, but if you're using Rails as intended, it is indeed an integral part of your application. That's what distinguishes frameworks from libraries.

If you're using libraries, you're following the Hollywood Principle: Don't call us, we'll call you. You have control over the application. If you're using a framework, [the framework calls you](https://martinfowler.com/bliki/InversionOfControl.html). In other words, you're just filling in the blanks in a pre-defined structure.

And it's especially pronounced in Rails thanks to the [Active Record pattern](https://www.martinfowler.com/eaaCatalog/activeRecord.html). Active Record is all about mixing data access logic (Rails!) with domain objects (your application!).

## So, what _is_ `lib` for?

Put briefly, the heart of your application lives in `app/`, and code that is _not specific to its domain_ goes into `lib/`.

Code that's not specific to your application's core domain may concern responsibilities like HTTP clients, authentication and authorization, (generic) serialization and deserialization, and so on. For these concerns, we usually don't write the code ourselves - we use libraries, gems. Almost always those are third party gems from [rubygems.org](https://rubygems.org/).

But what if what we need is not available in a well maintained library? What if the functionality we need is so small that it doesn't warrant introducing an external dependency? Something that we can easily write ourselves?

We want the code to live in the same repository as our application, but it's not specific to our application's domain. It's still library code. So it should go into `lib/`.

_It's right there in the name!_

💡 **`lib/` is for libraries.**

## Boundaries

The main advantage of separating library code from your application instead of just lumping it in with all of your other stuff is the reduction of cognitive load. Ideally, you can look at the library code and understand it without having to know any of the details of your application. The less you as a developer need to know to do your work the faster you can get things done, delivering value to your users and checking items off your to-do list.

Robert Martin writes in _Clean Architecture_:

> Software Architecture is the art of drawing lines that I call _boundaries_. Those boundaries separate software elements from one another, and restrict those on one side from knowing about those on the other.

Let's do some Software Architecture! 🧑‍💼

If software element A doesn't know about element B, that also means you can _understand_ element A without having to understand element B. In practice, "A doesn't know about B" means that A doesn't have _source code dependencies_ (AKA _static dependencies_) on B.

Remember, we want to be able to understand our libraries without having to understand or know any details of the application. Therefore, the code in `lib/` should not have dependencies on the code in `app/`.

💡 **The application depends on its libraries, but libraries never depend on the application.**

## Complication: Autoloading

In Rails versions before 7.1, `lib/` is not autoloaded, which means that if you want to use code from `lib/` in your application, you need to explicitly require it. While in theory this is a good thing because it makes a dependency explicit, requiring a file will add its contents to the global namespace. That means _requiring a file once, in one place, will make it available everywhere_, and implicit dependencies on it will creep in. So the advantage of explicit dependencies doesn't really exist in Rails apps in practice. Also, without autoloading, the code in `lib/` will not be reloaded after making changes locally, which is inconvenient.

But you don't want to autoload all of `lib/` either. There's likely a lot of code in there that your application doesn't need to run in a production environment, like rake tasks. Autoloading it in development implies eagerloading in production, which would slow down application startup and use up additional memory.

One good workaround has been [proposed](https://github.com/rails/rails/issues/37835#issuecomment-757367812) by prominent Rails contributor and autoloading expert Xavier Noria:

> The best practice [...] is to move that code to `app/lib`. Only the Ruby code you want to reload, tasks or other auxiliary files are OK in `lib`.

Any folder under `app/` will be autoloaded by default, including `app/lib/`.

In Rails 7.1, [a new default was introduced](https://github.com/rails/rails/pull/48572) to autoload `lib/`, specifically omitting the subfolders `lib/assets/`, `lib/tasks/` and `lib/generators/`, which means you don't need Xavier's workaround anymore.

So, going forward I will assume that the library code your application relies on is autoloaded - either it is in `app/lib/` or it is in `lib/` and autoloaded via Rails 7.1's `config.autoload_lib`.

💡 **Your application libraries should be autoloaded.**

## Making it so

Because in this setup libraries and application are versioned and tested together, it is easy to accidentally break the boundary by introducing a dependency on the application to the code in `lib/`. Most of the time, this will be a call to a model class. In a small, well aligned team, you can probably avoid this erosion for a while. But as the team grows and the application ages, at some point boundary violations will creep in.

The problem with an incomplete boundary is that you can't trust it. You can't be _sure_ that the code you're looking at is independent of the application; you have to check every time, and your cognitive load increases.

But I have good news for you: Because your library code is autoloaded, you can use a nifty little tool called [`packwerk`](https://github.com/shopify/packwerk)[^packwerk] to enforce the boundary.

Enforcing your library boundary with `packwerk` is easy. Start with

```sh
bundle add packwerk --group "development, test"
bundle binstub packwerk
bin/packwerk init
```

As part of the initialization process, `packwerk` will place a `package.yml` file in the root folder of your application, which defines the root package. All your code that is not explicitly in another package is in the root package.

⚠️ _In the following, replace `lib/` with `app/lib/` if you're using the `app/lib/` setup._

To enforce a boundary between application code and library code, we just drop another `package.yml` file into the `lib/` folder:

```yaml
# lib/package.yml

enforce_dependencies: true
dependencies: []
```

This tells packwerk that `lib/` is a package, code inside of it should respect the declared dependencies, and we don't want it to depend on any other package (not even the root package).

💡 Run `bin/packwerk validate` to validate packwerk's configuration files, which encompass `packwerk.yml` and all of the `package.yml`s you may have.

Now, if we run `bin/packwerk check`, we get a list of all the violations of the boundary we just defined. Ideally, this list is empty. Maybe there are a few entries there that you can easily rectify. But more likely, you have a long list of violations that you'll want to fix one by one.

To facilitate this, packwerk has a ratcheting mode where it accepts existing violations but complains about new ones. You can record existing violations by executing `bin/packwerk update-todo`. This will create to-do files for each package with violations. Check them into your version control system.

To get real value from `packwerk` you will want to add a step to your CI system that executes `bin/packwerk validate` (to validate the configuration) and `bin/packwerk check` (to enforce the boundaries).

## Conclusion

Rails' `lib/` folder is more than just a directory. It's a manifestation of a fundamental software engineering principle. By understanding and applying the concept of architectural boundaries, developers can create more maintainable, scalable, and understandable applications.

For many Rails developers, this is a new skill to master, which can seem daunting. However, the `lib/` folder is a great place to start, and `packwerk` can guide you on your way.

![Zelda: It's dangerous to go alone! Take this.](assets/lib-is-for-libraries/It's_dangerous_to_go_alone_Take_this_upscaled_2.png)

## Further Reading

- `packwerk` has extensive [usage docs](https://github.com/Shopify/packwerk/blob/master/USAGE.md).
- Awesome former teammate [Maple Ong](https://mapleong.me/) wrote a great blog post about [Enforcing Modularity in Rails Apps with Packwerk](https://shopify.engineering/enforcing-modularity-rails-apps-packwerk).
- You may also be interested in [my article on the Shopify blog](https://engineering.shopify.com/blogs/engineering/shopify-monolith) about the larger context of my modularity work at Shopify.
- For much shorter feedback cycles, if you're using VS Code, you can install [packwerk-vscode](https://marketplace.visualstudio.com/items?itemName=Gusto.packwerk-vscode) to see violations as you type.
- To avoid or resolve dependency cycles, you'll quickly find yourself needing a working unserstanding of [inversion of control and dependency injection](https://stackoverflow.com/questions/3058/what-is-inversion-of-control#3140). Create abstractions and invert dependencies so they are opposed to the control flow. It's an important topic that probably deserves its own article.

[^packwerk]: I developed the idea and core functionality of `packwerk` in 2020 during my time at Shopify, supported and inspired by a lot of very smart people around me. Together with the team we later polished the tool and open sourced it, and it has since found significant adoption in the Ruby on Rails community.
