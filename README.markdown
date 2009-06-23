Spiceworks TextMate bundle
--------------------

Develop Spiceworks Plugins with TextMate.

To learn more about Spiceworks and Spiceworks Plugins:

* [Spiceworks Home](http://spiceworks.com)
* Spiceworks Plugins
  * [Help Page](http://community.spiceworks.com/help/Plugins)
  * [API](http://community.spiceworks.com/help/Spiceworks_Plugin_API)
  * [Tutorials](http://community.spiceworks.com/help/Plugin_Tutorials)
  * [Plugins available for Install](http://community.spiceworks.com/plugin)

Installation
============

To install via Git:

    cd ~/"Library/Application Support/TextMate/Bundles/"
    git clone git://github.com/shad/spiceworks-tmbundle.git "Spiceworks.tmbundle"
    osascript -e 'tell app "TextMate" to reload bundles'

Source can be viewed or forked via GitHub: [http://github.com/shad/spiceworks-tmbundle/tree/master](http://github.com/shad/spiceworks-tmbundle/tree/master)


Usage
==========================

Open your project directory and add a file 'swconf' (If this file does not exist, it will be created on first attempt to save a spiceworks plugin):

    --- 
    environments: 
    - title: Development
      user: you@example.com
      url: http://localhost
      pass: password

    - title: Production
      user: you@example.com
      url: http://production-server
      pass: password


Create a new plugin in Spiceworks, view source on the plugin and grab the GUID by inspecting the &lt;tr&gt; element of `settings/plugins`.  Insert the `@guid` attribute into the `SPICEWORKS-PLUGIN` comment block like this:


    // ==SPICEWORKS-PLUGIN==
    // @name          My Plugin
    // @description   My Plugin Description
    // @version       0.1
    // @guid          p-597aa800-9708-012b-81c0-0016353cc494-1233697019
    // ==/SPICEWORKS-PLUGIN==


Create a file in your project directory for your new plugin.  Name it 'whatever-your-plugin-name-is.swjs'.  Make sure that TextMate recognizes it as a spiceworks plugin file (or change the type to be Spiceworks Plugin).  When you save this plugin using `Option-s` the plugin will also be published out to the server specified in 'swconf'.


Authors
=======
* Shad Reynolds [twitter/shadr](http://twitter.com/shadr)
* Justin Perkins