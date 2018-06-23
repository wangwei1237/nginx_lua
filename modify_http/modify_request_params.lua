---------------------------------------
--brief: modify the http request body for post or params for get.


modify_request_params={}
local M = modify_request_params
local cjson = require "cjson.safe"


-------------------------------------------------
-- brief
function M.init_configure(conf_file)
	local file = io.open(conf_file, "r")
	if file == nil then
		return nil
	end

	local conf = file:read("*all")
	file:close()

	conf = cjson.decode(conf)
	if conf == nil then
		return nil
	end

	return conf
end


function M.modify_get(conf)
	if ngx.req.get_method() ~= "GET" then
		return 1000
	end

	local normal_key = conf["normal"]
	local append_key = conf["append"]
	local uri_args   = ngx.req.get_uri_args()
	local v_cnt      = 1
	local v_i        = 1

	for k,v in pairs(normal_key) do
		v_cnt = table.getn(v)
		v_i   = math.random(1, v_cnt)
		uri_args[k] = v[v_i]
	end

	for k,v in pairs(append_key) do
		v_cnt = table.getn(v)
		v_i   = math.random(1, v_cnt)

		if uri_args[k] == nil then
			uri_args[k] = ""
		end

		uri_args[k] = uri_args[k] .. v[v_i]
	end

	ngx.req.set_uri_args(cjson.encode(uri_args))
end


function M.modify_post(conf)
	if ngx.req.get_method() ~= "POST" then
		return 1000
	end

	ngx.req.read_body()
	local uri_args = ngx.req.get_post_args()
	local normal_key = conf["normal"]
	local append_key = conf["append"]
	local v_cnt      = 1
	local v_i        = 1

	for k,v in pairs(normal_key) do
		v_cnt = table.getn(v)
		v_i   = math.random(1, v_cnt)
		uri_args[k] = v[v_i]
	end

	for k,v in pairs(append_key) do
		v_cnt = table.getn(v)
		v_i   = math.random(1, v_cnt)

		if uri_args[k] == nil then
			uri_args[k] = ""
		end

		uri_args[k] = uri_args[k] .. v[v_i]
	end

	uri_args = cjson.encode(uri_args)
	ngx.req.set_body_data(uri_args)
end


function M.modify()
	local nginx_install_path = ngx.config.prefix()
	local conf_file          = nginx_install_path .. "/conf/lua/modify_request_params.conf"
	local conf               = M.init_configure(conf_file)
	if conf == nil then
		return
	end

	M.modify_get(conf)
	M.modify_post(conf)
end


return M