import { Server } from 'socket.io'
import { Server as HttpServer } from 'http'

let io: Server | null = null

export function initSocket(httpServer: HttpServer): Server {
  io = new Server(httpServer, {
    cors: {
      origin: process.env.NODE_ENV === 'production'
        ? ['https://admin.soukna.mr', 'https://soukna.mr']
        : ['http://localhost:3002', 'http://localhost:5173', 'http://localhost:5174', 'http://localhost:3080'],
      credentials: true,
    },
  })

  io.on('connection', (socket) => {
    // Client sends their userId to join their private room
    socket.on('join', (userId: string) => {
      socket.join(`user:${userId}`)
    })

    socket.on('disconnect', () => {
      // cleanup automatic
    })
  })

  console.log('🔌 Socket.io initialized')
  return io
}

export function getIO(): Server {
  if (!io) throw new Error('Socket.io not initialized')
  return io
}
