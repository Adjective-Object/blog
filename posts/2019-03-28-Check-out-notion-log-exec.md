---
title: 🗒 Check out notion-log-exec
tags: notion, meta
---

I'm continuing to build out little notion-related tools while automating the publishing of this blog.



<section class="columnSplit" style="display:flex;"><section style="flex: 0.5000000000000001; padding: 0.5em">
![](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fccdf551b-b6a3-47b3-b682-155a3d0d70f5%2Fout-pass.gif)

A demo job passing

</section>
<section style="flex: 0.5; padding: 0.5em">
![](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F1c2cf3d0-918f-45bb-8144-9d61ae942182%2Fout-fail.gif)

A demo job failing. It updates the icon.

</section></section>

This one is pretty small and self-contained. [notion-log-sync](https://github.com/adjective-object/notion-log-exec) runs a shell command, records the output, and posts it back to a row with a matching name in a notion CollectionRow.



[Check it on pypi](https://pypi.org/project/notion-log-exec/)!



I've had a fun time automating the CI/CD process to publish package revisions immediately from github. Maybe I'll write a follow-up post about automating the deployment process? We'll see.. 😛

