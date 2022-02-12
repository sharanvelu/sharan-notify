<?php

/**
 * @param string $path
 * @param $secure
 * @return string
 */
function remainderAsset(string $path, $secure = null)
{
    $path = 'images/remainder/' . $path;
    return asset($path, $secure);
}
