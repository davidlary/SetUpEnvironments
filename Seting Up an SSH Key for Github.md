# Seting Up an SSH Key for Github

In a terminal window type:

   ```
ssh-keygen -t ed25519 -C "davidlary@me.com"
   ```

This will the say something like: Your identification has been saved in /Users/davidlary/.ssh/id_ed25519


Then copy the key to the clipboard with

   ```
pbcopy < /Users/davidlary/.ssh/id_ed25519.pub
   ```

Then at the URL 

   ```
https://github.com/settings/keys
   ```
   
   click on the green New SSH Key button and paste in the key. That's it!
   


