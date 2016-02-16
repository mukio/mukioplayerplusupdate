writers = {}
function onConnection(client,...)
    writers[client] = client.writer:newFlowWriter()
	
	function client:dispatchData(data,rnd,...)
        for client,writer in pairs(writers) do
            writer:writeAMFMessage("onServerData",data,rnd)
        end
        return "Success"
    end
end

function onDisconnection(client)
    writers[client] = nil
end
