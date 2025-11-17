import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [msg, setMsg] = useState('…loading…')

  useEffect(() => {
    fetch('/api/message')
      .then(r => r.json())
      .then(d => setMsg(d.message))
      .catch(() => setMsg('Failed to load'))
  }, [])

  return (
    <main style={{ fontFamily: 'system-ui', padding: 24 }}>
      <h1>{msg} :)</h1>
    </main>
  )
}

export default App
