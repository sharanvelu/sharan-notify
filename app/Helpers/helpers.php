<?php

/**
 * @return bool
 */
function isOfficeHours()
{
    return (now()->hour >= 9) && (now()->hour < 20);
}
