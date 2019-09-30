<?php
define('WP_AUTO_UPDATE_CORE', 'minor');// This setting is required to make sure that WordPress updates can be properly managed in WordPress Toolkit. Remove this line if this WordPress website is not managed by WordPress Toolkit anymore.
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wp_lk86w' );

/** MySQL database username */
define( 'DB_USER', 'wp_wiluv' );

/** MySQL database password */
define( 'DB_PASSWORD', 'wQ1!DTef3g7n45SR' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost:3306' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY', '7Q4P|r58ffF(T5JH0d6|;7~3*at61)C!j_Ok%v2bgtMi~bVZ39DApoAc/V+/!ACj');
define('SECURE_AUTH_KEY', 'H1W%QS9_qH2b)wm7I_O&#G]e6b4(68|-A#[cnMUu98!+G)4)hmP~8GAzG-QE#It9');
define('LOGGED_IN_KEY', 'P&u4pUzcf+:VKA]|x5Qh0_rn2vPZrDMU6ti006dP]1m(G(5n7U-90Y!47!++u3wd');
define('NONCE_KEY', '7|]40@[E79ZI#f-9w7%6CzuQ4|;pX0ZRp1YYN22)6izEtuI2zt8ZFO(RXE3g#9@3');
define('AUTH_SALT', '!Nsk]7lwtWT66wt*;2Dae9_N(%x8i4bwKkCY(AhMr:z5+*4|P-;]OL083VB(4y_H');
define('SECURE_AUTH_SALT', '9O6*32t1h4&2Ny46%bNIusn50q##X15Gq:)|!|tkwe6|5[9YE2waJ2+i!5JSmz--');
define('LOGGED_IN_SALT', '8_[ug!90zsH73%tPF(1YuwvmU(3ZND12WCbgcL+JNf51r9:3:cZ)t93a_1+h(@89');
define('NONCE_SALT', 'Y&6_a&%!|Nm#;P%[Cy&49YJNr31+21E73k4Ax9GXg4jq~W8_s7a(*J]zma4O38Lb');

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = '3rHX1W_';


define('WP_ALLOW_MULTISITE', true);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
