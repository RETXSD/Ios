import express from 'express'
import fetch from 'node-fetch'
import dotenv from 'dotenv'

dotenv.config()

const app = express()
app.use(express.json())

app.post('/chat', async (req, res) => {
  try {
    const requestBody = {
      ...req.body,
      model: process.env.DEEPSEEK_MODEL || 'deepseek-v4-flash'
    }

    const response = await fetch(`${process.env.DEEPSEEK_BASE_URL}/v1/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`
      },
      body: JSON.stringify(requestBody)
    })

    const data = await response.json()
    res.status(response.status).json(data)
  } catch (error) {
    res.status(503).json({ error: 'AI proxy unavailable' })
  }
})

const port = Number(process.env.PORT || 3000)
const host = process.env.HOST || '10.24.203.75'

app.listen(port, host, () => {
  console.log(`AI Proxy running on http://${host}:${port}`)
  console.log('From your iPhone, use your iMac LAN IP, for example http://10.24.203.75:3000')
})
