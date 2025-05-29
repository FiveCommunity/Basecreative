fx_version "cerulean"
game "gta5"
lua54 "yes"

this_is_a_map "yes"

client_scripts {
	"client/*"
}

files {
	"stream/*",
	"stream/**/*",
	"stream/**/**/*",
	"stream/**/**/**/*",
	"interiorproxies.meta"
}

data_file "DLC_ITYP_REQUEST" "stream/*.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/**/*.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/**/**/*.ytyp"
data_file "INTERIOR_PROXY_ORDER_FILE" "interiorproxies.meta"