# Installing Claude Code on a Mac

## Install Home Brew

To install Homebrew on a Mac open a terminal and run:

   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```


## Install Node.js

Once Homebrew is installed, install Node.js (which includes npm) by running:

   ```
   brew install node
   ```

Verify the installation was successful by checking the version numbers:

   ```
   node -v
   npm -v
   ```

Both commands should return version numbers if the installation was successful.


## Install Claude Code

Open your Terminal application and run the following command:


```
npm install -g @anthropic-ai/claude-code
```

This is the official npm package for Claude Code, which is currently in beta as a research preview. Note that it's recommended to install as a non-privileged user (not using sudo) to avoid permission issues and security risks.

If you encounter permission errors during installation, you may need to configure npm to use a directory within your home folder instead of system directories. Here's how to do that:

1. Create a directory for your global packages:
   ```
   mkdir -p ~/.npm-global
   ```

2. Configure npm to use this new directory:
   ```
   npm config set prefix ~/.npm-global
   ```

3. Add the new path to your shell configuration:
   ```
   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
   ```
   (If you use zsh, replace ~/.bashrc with ~/.zshrc)

4. Apply the new PATH setting:
   ```
   source ~/.bashrc
   ```
   (If you use zsh source  ~/.zshrc)

5. Now install Claude Code in this new location:
   ```
   npm install -g @anthropic-ai/claude-code
   ```

After installation, you can start using Claude Code by navigating to your project directory and running the `claude` command. You'll need to complete a one-time OAuth process with your Anthropic account.

## Configuration

You can configure Claude Code by running `claude config` in your terminal, or using the `/config` command when in the interactive mode. Claude Code supports both global and project-level configuration.

## System Requirements

Claude Code supports macOS 10.15 or later.

Note that Claude Code is currently in beta as a research preview, so the functionality and features may evolve over time.
