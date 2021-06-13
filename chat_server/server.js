const users = {}
    //  usersDescriptorObjects = {userName: "",password: ""};

const rooms = {}
    //roomDescriptorObjects  = {roomName: "",description:"", maxPeople: 99, private: true|false, creator:"", users: []}

var server_port = process.env.PORT || 3000;
const io = require("socket.io")(require("http").createServer(function() {}).listen(server_port, function(err) {
    if (err) throw err
    console.log('Listening on port %d', server_port);
}));
//construct a http server, wrapped in a socket.io server and start it up.

io.on("connection", function(client) {
    console.log("\n\nConnection established with a client");

    io.sockets.emit("not", "hello");

    client.on("test", function name(data) {
        console.log(data)
    })


    client.on("validate", function name(data) {
        console.log("\nMSG: validate ", data);
        const user = users[data.userName];
        if (user) {
            if (user.password === data.password) {
                console.log("status: ok");
                //io.sockets.emit("validate", "status: ok");
                io.sockets.emit("status", "validate:ok");
                // callback({ status: "ok" });
            } else {
                console.log("status: fail");
                //io.sockets.emit("validate", "status: fail");
                io.sockets.emit("status", "validate:fail");
                // callback({ status: "fail" });
            }
        } else {
            users[data.userName] = data;
            console.log("status: created");
            //io.sockets.emit("validate", "status: created");
            io.sockets.emit("status", "validate:created");
            io.sockets.emit("newUser", users);
            // callback({ status: "created" });
        }

    })





    client.on("create", function name(data) {
        console.log("\nMSG: create ", data);
        if (rooms[data.roomName]) {
            console.log("Room already exists");
            io.sockets.emit("status", "create:exists");
            //callback({ status: "exists" });
        } else {
            data.users = {};
            console.log('data: ', data);
            console.log('rooms = ', rooms);
            rooms[data.roomName] = data;
            console.log('rooms = ', rooms);
            io.sockets.emit("created", rooms);
            io.sockets.emit("status", "create:created");
            //callback({ status: "created", rooms: rooms });
        }
    })

    client.on("listRooms", function name(data) {
        console.log("list_of_Rooms: ", rooms)
        io.sockets.emit("allRooms", rooms);
        //callback(rooms);
    })

    client.on("listUsers", function name(data) {
        console.log("list_of_Users: ", users)
        io.sockets.emit("allUsers", users);
        //callback(users);
    })

    client.on("join", function name(data) {
        console.log("\nMSG: join ", data);
        const room = rooms[data.roomName];
        console.log('the_room = ', room);
        if (Object.keys(room.users).length >= rooms.maxPeople) {
            console.log("Room is full");
            io.sockets.emit("status", "join:full");
            //callback({ status: "full" });

        } else {
            console.log('room.users BEFORE = ', room.users);
            room.users[data.userName] = users[data.userName];
            console.log('room.users AFTER = ', room.users);
            io.sockets.emit("joined", room);
            io.sockets.emit("status", "join:joined");
            //callback({ status: "joined", room: room })
        }
    })

    client.on("leave", function name(data) {
        console.log("\nMSG: leave ", data);
        const room = rooms[data.roomName]
        console.log('room.users BEFORE = ', room.users);
        delete room.users[data.userName]
        console.log('room.users AFTER = ', room.users);
        io.sockets.emit("left", room)
        io.sockets.emit("status", "leave:left");
    })


    client.on("post", function name(data) {
        console.log("\nMSG: post", data);
        io.sockets.emit("posted", data);
        io.sockets.emit("status", "post:ok");
    })

    client.on("invite", function name(data) {
        console.log("\nMSG: invite", data);
        io.sockets.emit("invited", data);
        io.sockets.emit("status", "invite:ok");
        //callback({ status: "ok" })
    })


    client.on("close", function name(data) {
        console.log("\nMSG: close", data);

        delete rooms[data.roomName]
        console.log('rooms AFTER = ', rooms);

        io.sockets.emit("closed", { "roomName": data.roomName, "rooms": rooms })
        io.sockets.emit("status", "close:closed");
    })

    client.on("kick", function name(data) {
        console.log("\nMSG: kick", data);

        const room = rooms[data.roomName]
        console.log('room BEFORE = ', room)

        const user = room.users
        console.log('users BEFORE = ', user)

        delete user[data.userName]
        console.log('room AFTER = ', room)
        console.log('room AFTER = ', user)

        io.sockets.emit("kicked", room)
        io.sockets.emit("status", "kick:kicked");
        //callback({ status: "ok" })
    })
})