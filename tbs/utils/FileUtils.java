package com.san.coap.modules.tbs.utils;

import java.io.File;

public class FileUtils {
    public static boolean fileIsExists(String strFile)
    {
        try {
            File file = new File(strFile);
            if(!file.exists()) {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
        return true;
    }

    public static String fileName(String strFile) {
        return strFile.substring(strFile.lastIndexOf("/") + 1);
    }
}

