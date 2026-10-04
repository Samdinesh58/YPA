/**
 * model/services/ImageService.cfc
 * -------------------------------
 * Saves uploaded images safely and deletes old ones.
 *
 * Safety rules for uploads:
 *   - only JPG, PNG, GIF and WebP, checked by reading the file's first bytes
 *     (the "magic number"), not by trusting the file name
 *   - at most 5 MB
 *   - saved under assets/uploads/<folder>/ with a new random name, so a
 *     visitor can never choose the file name or overwrite another file
 *   - SVG is not allowed, because SVG files can contain scripts
 *
 * Paths are stored in the database relative to the site root, e.g.
 * "assets/uploads/professors/0f8c...e1.jpg".
 */
component {

    variables.maxBytes   = 5 * 1024 * 1024;
    variables.uploadRoot = "assets/uploads/";
    // This file is in /model/services/, so the site root is two folders up.
    variables.rootPath   = getDirectoryFromPath( getCurrentTemplatePath() ) & "../../";

    /**
     * Saves the file sent in the form field fieldName into
     * assets/uploads/<folder>/ and returns its relative path.
     * Returns "" when no file was chosen.
     * Throws type "ImageService.Invalid" with a friendly message when the
     * file is not an acceptable image.
     */
    public string function saveUpload( required string fieldName, required string folder ) {
        if ( !structKeyExists( form, arguments.fieldName ) || !len( form[ arguments.fieldName ] ) ) {
            return "";
        }
        if ( !reFind( "^[a-z]+$", arguments.folder ) ) {
            throw( type = "ImageService.Invalid", message = "Invalid upload folder." );
        }

        // 1. Let Lucee put the upload in the temp folder first.
        var upload   = fileUpload( getTempDirectory(), arguments.fieldName, "", "makeunique" );
        var tempFile = upload.serverDirectory & "/" & upload.serverFile;

        try {
            // 2. Check size and real file type.
            if ( upload.fileSize > variables.maxBytes ) {
                invalid( "The image is too large. Please keep it under 5 MB." );
            }
            var extension = detectImageType( tempFile );
            if ( !len( extension ) ) {
                invalid( "Please upload a JPG, PNG, GIF or WebP image." );
            }

            // 3. Move it into place with a random name.
            var relativePath = variables.uploadRoot & arguments.folder & "/" & lCase( createUUID() ) & "." & extension;
            var destination  = variables.rootPath & relativePath;
            var folderPath   = getDirectoryFromPath( destination );
            if ( !directoryExists( folderPath ) ) {
                directoryCreate( folderPath, true );
            }
            fileMove( tempFile, destination );
            return relativePath;
        } finally {
            // Never leave rejected uploads lying around in the temp folder.
            if ( fileExists( tempFile ) ) {
                fileDelete( tempFile );
            }
        }
    }

    /**
     * Deletes an image saved by saveUpload(). Does nothing for empty paths
     * or for anything outside assets/uploads/ (e.g. hand-entered URLs).
     */
    public void function deleteImage( string relativePath = "" ) {
        var path = trim( arguments.relativePath );
        if ( !len( path ) || left( path, len( variables.uploadRoot ) ) != variables.uploadRoot || find( "..", path ) ) {
            return;
        }
        var fullPath = variables.rootPath & path;
        if ( fileExists( fullPath ) ) {
            fileDelete( fullPath );
        }
    }

    /** Reads the first bytes of the file and returns jpg/png/gif/webp, or "". */
    private string function detectImageType( required string filePath ) {
        var fileHandle = fileOpen( arguments.filePath, "readBinary" );
        try {
            var head = binaryEncode( fileRead( fileHandle, 12 ), "hex" );
        } finally {
            fileClose( fileHandle );
        }

        if ( left( head, 6 ) == "FFD8FF" )           return "jpg";
        if ( left( head, 16 ) == "89504E470D0A1A0A" ) return "png";
        if ( left( head, 8 ) == "47494638" )         return "gif";
        if ( left( head, 8 ) == "52494646" && mid( head, 17, 8 ) == "57454250" ) return "webp";
        return "";
    }

    private void function invalid( required string message ) {
        throw( type = "ImageService.Invalid", message = arguments.message );
    }

}
