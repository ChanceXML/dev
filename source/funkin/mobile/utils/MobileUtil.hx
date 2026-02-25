package funkin.mobile.utils;

#if android
import extension.androidtools.os.Build.VERSION;
import extension.androidtools.os.Environment;
import extension.androidtools.Permissions;
import extension.androidtools.Settings;
#end

import lime.system.System;
import lime.app.Application;
import openfl.Assets;
import haxe.io.Bytes;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class MobileUtil {

  public static var currentDirectory:String = null;

  public static function getDirectory():String {
    #if android
    var preferredPath = "/storage/emulated/0/.CodenameEngine-v1.0.1/";

    try {
        if (!FileSystem.exists(preferredPath)) {
            FileSystem.createDirectory(preferredPath);
        }
    } catch (e:Dynamic) {
        trace("Failed to create external directory: " + e);
    }

    return preferredPath;

    #elseif ios
    return System.documentsDirectory;
    #else
    return "";
    #end
  }

  public static function getPermissions():Void {
    try {
        #if android
        if (VERSION.SDK_INT >= 30) {
            if (!Environment.isExternalStorageManager()) {
                Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
            }
        }
        else if (VERSION.SDK_INT == 29) {
            try {
                if (!Environment.isExternalStorageManager()) {
                    Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
                }
            } catch (e1:Dynamic) {
                trace('Fallback 1 failed: $e1');
            }

            try {
                Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
            } catch (e2:Dynamic) {
                trace('Fallback 2 failed: $e2');
            }
        }
        else {
            Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
        }
        #end

        var targetDir = MobileUtil.getDirectory();
        if (!FileSystem.exists(targetDir)) {
            try {
                FileSystem.createDirectory(targetDir);
                trace('Successfully created directory: $targetDir');
            } catch (e:Dynamic) {
                trace('Failed to create directory $targetDir: $e');
            }
        }

    } catch (e:Dynamic) {
        trace('Error on creating directory: $e');
    }
  }

  public static function save(fileName:String = 'Ye', fileExt:String = '.txt', fileData:String = 'Nice try, but you failed, try again!') {
    var savesDir:String = MobileUtil.getDirectory() + 'saves/';

    if (!FileSystem.exists(savesDir))
      FileSystem.createDirectory(savesDir);

    File.saveContent(savesDir + fileName + fileExt, fileData);
  }

  public static function copyAssetsFromAPK(sourcePath:String = "assets/", targetPath:String = null):Void {
    #if mobile
    if (targetPath == null) {
        targetPath = getDirectory() + "assets/";
    }
    
    try {
        if (!FileSystem.exists(targetPath)) {
            FileSystem.createDirectory(targetPath);
        }

        copyAssetsRecursively(sourcePath, targetPath);
        trace('Assets successfully copied to: $targetPath');

    } catch (e:Dynamic) {
        trace('Error copying assets: $e');
    }
    #end
  }

  public static function copyModsFromAPK(sourcePath:String = "mods/", targetPath:String = null):Void {
    #if mobile
    if (targetPath == null) {
        targetPath = getDirectory() + "mods/";
    }
    
    try {
        if (!FileSystem.exists(targetPath)) {
            FileSystem.createDirectory(targetPath);
        }

        copyAssetsRecursively(sourcePath, targetPath);
        trace('Mods successfully copied to: $targetPath');

    } catch (e:Dynamic) {
        trace('Error copying mods: $e');
    }
    #end
  }

  private static function copyAssetsRecursively(sourcePath:String, targetPath:String):Void {
    #if mobile
    try {
        var cleanSourcePath = sourcePath;
        if (StringTools.endsWith(cleanSourcePath, "/")) {
            cleanSourcePath = cleanSourcePath.substring(0, cleanSourcePath.length - 1);
        }
        
        var assetList:Array<String> = Assets.list();
        
        for (assetPath in assetList) {
            if (StringTools.startsWith(assetPath, cleanSourcePath)) {
                var relativePath = assetPath;

                if (StringTools.startsWith(relativePath, "assets/")) {
                    relativePath = relativePath.substring(7);
                }

                if (relativePath == "") continue;

                var fullTargetPath = targetPath + relativePath;
                var targetDir = haxe.io.Path.directory(fullTargetPath);

                if (targetDir != "" && !FileSystem.exists(targetDir)) {
                    createDirectoryRecursive(targetDir);
                }

                try {
                    if (Assets.exists(assetPath)) {
                        var fileData:Bytes = Assets.getBytes(assetPath);
                        if (fileData != null) {
                            File.saveBytes(fullTargetPath, fileData);
                        } else {
                            var textData = Assets.getText(assetPath);
                            if (textData != null) {
                                File.saveContent(fullTargetPath, textData);
                            }
                        }
                    }
                } catch (e:Dynamic) {
                    trace('Error copying file $assetPath: $e');
                }
            }
        }
    } catch (e:Dynamic) {
        trace('Error in recursive copy: $e');
    }
    #end
  }

  private static function createDirectoryRecursive(path:String):Void {
    #if mobile
    if (FileSystem.exists(path)) return;
    
    var pathParts = path.split("/");
    var currentPath = "";

    for (part in pathParts) {
        if (part == "") continue;
        currentPath += "/" + part;

        if (!FileSystem.exists(currentPath)) {
            try {
                FileSystem.createDirectory(currentPath);
            } catch (e:Dynamic) {
                trace('Error creating directory $currentPath: $e');
            }
        }
    }
    #end
  }
}
