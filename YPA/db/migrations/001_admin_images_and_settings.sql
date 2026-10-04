-- =========================================================================
-- db/migrations/001_admin_images_and_settings.sql
-- Adds what the admin area needs:
--   * an image column on branches, events and students
--     (professors and achievers already have photo_url)
--   * a site_settings table for the poster image and tagline
--
-- Run once, after db/schema.sql:
--   mysql -u root -p ypa_academy < db/migrations/001_admin_images_and_settings.sql
-- =========================================================================

ALTER TABLE branches ADD COLUMN image_url VARCHAR(255) NULL AFTER phone;
ALTER TABLE events   ADD COLUMN image_url VARCHAR(255) NULL AFTER branch_id;
ALTER TABLE students ADD COLUMN photo_url VARCHAR(255) NULL AFTER branch_id;

-- Simple key/value store for site-wide settings edited in the admin area.
--   poster_image   : path of the uploaded poster, e.g. assets/uploads/poster/abc.jpg
--   poster_tagline : the line under "YPA Academy" on the poster
CREATE TABLE site_settings (
    setting_key    VARCHAR(64)  NOT NULL,
    setting_value  TEXT         NULL,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
