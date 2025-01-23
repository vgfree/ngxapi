module(...)

OWN_INIT = {
	-->1
	 'account_manager.deploy.init',

	-->2
	 'storage_manager.deploy.init',

	-->2
	 'fsystem_manager.deploy.init',
}

OWN_LINK = {
	-->1
	 'account_manager.deploy.link',

	-->2
	 'storage_manager.deploy.link',

	-->2
	 'fsystem_manager.deploy.link',
}

OWN_INFO = {
    LOGLV = 0,
    POOLS = true,
    PERF = true,
}
