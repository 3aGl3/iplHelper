resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

name 'IPL Helper'
description 'Provides access to server sided IPL loading and unloading.'
author '3aGl3'
version '1.0.0'

client_script 'iplloader_c.lua'
server_script 'iplloader_s.lua'

server_export 'RequestIpl'
server_export 'RemoveIpl'
server_export 'IsIplActive'
