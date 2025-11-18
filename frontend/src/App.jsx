import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [msg, setMsg] = useState('…loading…')
  const [demos, setDemo] = useState([])
  const [hits, setHits] = useState(null)

  useEffect(() => {
    fetch('/api/message')
      .then(r => r.json())
      .then(d => {
        setMsg(d.message)
        setHits(d.hits)
      })
      .catch(() => {
        setMsg('Failed to load')
        setHits(null)
      })

    fetch('/api/dbdemo')
      .then(r => r.json())
      .then(d => setDemo(d))
      .catch(() =>
        setDemo([{ id: 0, name: 'Failed to load', description: 'Error' }])
      )
  }, [])

  return (
    <main style={{ fontFamily: 'system-ui', padding: 24 }}>
      <h1>{msg} :)</h1>

      <p style={{ color: 'green' }}>
        Redis says you've visited this page {hits} times :)
      </p>

      <div>
        {demos.map(item => (
          <div key={item.id}>
            <strong>{item.name}</strong> — {item.description}
          </div>
        ))}
      </div>
    </main>
  )
}

export default App
