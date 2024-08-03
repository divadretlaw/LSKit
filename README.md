# LSKit

Tools for manipulating Baldur's Gate 3 files

## Examples

### Load information from a mod

```swift
let bg3 = URL.homeDirectory.appending(path: "Library/Application Support/Baldur's Gate 3/")
let url = bg3.appending(path: "Mods/<mod>.pak")
let pak = try ModLSPK(url: url)

guard let moduleInfo = pak.meta.moduleInfo else {
    return // File does not contain a meta.lsx with ModuleInfo
}
guard let moduleInfo = moduleInfo.publishVersion else {
    return // ModuleInfo does not contain publish version info
}

// Access desired information e.g.
print(moduleInfo.uuid) // UUID
print(moduleInfo.name) // Name
print(moduleInfo.folder) // Folder
```

### Load mod settings

```swift
let bg3 = URL.homeDirectory.appending(path: "Library/Application Support/Baldur's Gate 3/")
let url = bg3.appending(path: "PlayerProfiles/Public/modsettings.lsx")

guard let lsx = LSX(url: url) else {
    return // Unable to read or parse given LSX file
}
guard let moduleSettings = LSX.ModuleSettings(lsx: lsx) else {
    return // LSX is not in the correct format
}

// Access desired information e.g.
print(moduleSettings.modOrder) // Mod Order
print(moduleSettings.mods) // Mods
```

## Acknowledgment

This is package couldn't exist without [Norbyte](https://github.com/Norbyte)'s [LSLib](https://github.com/Norbyte/lslib).

This package aims to provide a small subset of LSLib's features, re-implemented in Swift to make them available on Apple platforms.

## License

See [LICENSE](LICENSE)
