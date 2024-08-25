# ThorVG for Swift
<p align="center">
  <img width="800" height="auto" src="https://github.com/thorvg/thorvg/blob/main/res/logo/512/thorvg-banner.png">
</p>

A Swift wrapper on top of the ThorVG C++ API.

The upstream ThorVG repository is included in this repository as a submodule. To view the upstream documentation, click here.

Current upstream ThorVG version: [`v0.14.7`](https://github.com/thorvg/thorvg/releases/tag/v0.14.7), commit SHA: [`e3a6bf`](https://github.com/thorvg/thorvg/commit/e3a6bf5229a9671c385ee78bc33e6e6b611a9729).

### Contributing
Before building the Swift Package in Xcode, ensure that you update the submodule and run the copy_config.sh script.

Both of these commands are bundled into a setup script that you can run easily:

```bash
./setup.sh
```

**Note:** The ThorVG source code uses the meson build system to generate build artifacts, including a `config.h` file that is required during compilation.

Since Swift Package Manager (SPM) requires all necessary files to be present in the target directory at compile time, we need to generate this `config.h` file ahead of time so that SPM can access it and successfully build all of the C++ source files.

The `setup.sh` script takes care of copying a pre-built `config.h` file into the correct location within the `thorvg/src` directory, so you don't have to worry about it.

**Important:** As a result of this process, contributors will always see an extra `config.h` file in the git status of the ThorVG submodule. This is expected, and you can simply ignore this file when reviewing changes or making commits.