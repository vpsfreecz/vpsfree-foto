<?php
// Dedicated copy of native PhotoShow state, never the original production tree.
$config->photos_dir = getenv('PHOTOSHOW_PHOTOS_DIR') ?: '/var/lib/photoshow-preview/photos';
$config->ps_generated = getenv('PHOTOSHOW_GENERATED_DIR') ?: '/var/lib/photoshow-preview/generated';
$config->timezone = 'Europe/Prague';
