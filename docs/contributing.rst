Contributing
========================

Contribute to the vCheck-vSphere repository
------------------------

Hi! We can't thank you enough for wanting to contribute; the community is what keeps the wheels moving on this awesome project.
All we ask is that you follow some simple guidelines. The roots of these guidelines stem from the developer community and the actual document has been borrowed from `Microsoft's DscResources`_ repository; they did an excellent job putting these guidelines together; why reinvent the wheel?

.. _`Microsoft's DscResources`: https://github.com/PowerShell/DscResources

Using GitHub, Git, and this repository
------------------------

We are working on more detailed instructions that outline the basics.

Contributing to the existing vCheck-vSphere repository
------------------------

Forks and Pull Requests
~~~~~~~~~~~~~~~~~~~~~~~~

GitHub fosters collaboration through the notion of `pull requests`_.
On GitHub, anyone can fork_ an existing repository into their own branch where they can make private changes to the original repository.
To contribute these changes back into the original repository, a user simply creates a pull request in order to "request" that the changes be taken "upstream".

.. _fork: https://help.github.com/articles/fork-a-repo/
.. _`pull requests`: https://help.github.com/articles/using-pull-requests/

Lifecycle of a pull reqeust
~~~~~~~~~~~~~~~~~~~~~~~~

* **Always create pull requests to the `dev` branch of a repository**.

For more information, learn about the `branch structure`_ that we are using.

* When you create a pull request, fill out the description with a summary of what's included in your changes. If the changes are related to an existing GitHub issue, please reference the issue in your description.
* Once the PR is submitted, we will review your code
* Once the code review is done, and all merge conflicts are resolved, a maintainer will merge your changes.

..

Contributing to documentation
~~~~~~~~~~~~~~~~~~~~~~~~

More information to come about how to contribute to documentation!

Editing an existing plugin
------------------------

We are in the process of adding/consolidating more detailed documentation around this.

Creating a new plugin
------------------------

We are in the process of adding/consolidating more detailed documentation around this.

Slack
------------------------

To join in discussions or ask questions, join the #vCheck channel on `VMware Code Slack Team`_.

.. _VMware Code Slack Team: https://code.vmware.com/slack/

Style guidelines
------------------------

When contributing to this repository, please follow the following guidelines:

* For all indentation, use 4 spaces instead of tab stops
* Make sure all files are encoding using UTF-8.
* ``lf`` line endings are preferred
* Remove empty whitespace at the end of each line/file (most modern text editors allow you to do this by enabling a setting)


.. _brach-structure:

Branch structure
------------------------

We are using a `git flow`_ model for development. We recommend that you create local working branches that target a specific scope of change. Each branch should be limited to a single feature/bugfix both to streamline workflows and reduce the possibility of merge conflicts.

    .. image:: http://nvie.com/img/git-model@2x.png

    .. _git flow: http://nvie.com/posts/a-successful-git-branching-model/
