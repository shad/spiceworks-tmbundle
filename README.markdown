Spiceworks TextMate bundle
--------------------

Develop Spiceworks Plugins from an TextMate.

Installation
============

To install via Git:

    cd ~/"Library/Application Support/TextMate/Bundles/"
    git clone git://github.com/shad/spiceworks-tmbundle.git "Spiceworks.tmbundle"
    osascript -e 'tell app "TextMate" to reload bundles'

Source can be viewed or forked via GitHub: [http://github.com/shad/spiceworks-tmbundle/tree/master](http://github.com/shad/spiceworks-tmbundle/tree/master)


Usage
==========================

Open your project settings and add the following environment variables.

    SPICEWORKS_SERVER   (ex: http://localhost/)
    SPICEWORKS_USER     (ex: myname@mycompany.com)
    SPICEWORKS_PASSWORD (ex: flubberdoo)

Create a new plugin in Spiceworks, view source on the plugin and grab the GUID by inspecting the &lt;tr&gt; element of `settings/plugins`.  Insert the `@guid` attribute into the `SPICEWORKS-PLUGIN` comment block like this:

    // ==SPICEWORKS-PLUGIN==
    // @name          My Plugin
    // @description   My Plugin Description
    // @version       0.1
    // @guid          p-597aa800-9708-012b-81c0-0016353cc494-1233697019
    // ==/SPICEWORKS-PLUGIN==

Now, when you save this plugin using `Option-s` the plugin will also be published out to the server specified in the environment variables.


Advanced Usage
==============================

You can also specify the server, user and password directly in the text of the script, but this is only for testing and you should be very carful not to share your plugin with this information included.

    // ==SPICEWORKS-PLUGIN==
    // @name          My Plugin
    // @description   My Plugin Description
    // @version       0.1
    // @guid          p-597aa800-9708-012b-81c0-0016353cc494-1233697019
    //
    // @server        http://localhost
    // @user          myuser
    // @password      mypassword
    // ==/SPICEWORKS-PLUGIN==




Author
=======
* Shad Reynolds, [shad.reynolds@gmail.com](mailto:shad.reynolds@gmail.com)
* [twitter/shadr](http://twitter.com/shadr)