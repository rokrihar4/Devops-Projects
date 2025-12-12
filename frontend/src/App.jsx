import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [msg, setMsg] = useState('…loading…')
  const [hits, setHits] = useState(null)

  const [items, setItems] = useState([])     // DB items: [{id,name,description,...}]
  const [text, setText] = useState("")

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

    loadItems()
  }, [])

  function loadItems() {
    fetch('/api/items')
      .then(r => r.json())
      .then(setItems)
      .catch(() => setItems([]))
  }

  async function addItem() {
    const name = text.trim()
    if (!name) return

    const res = await fetch('/api/items', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, description: '' })
    })

    if (!res.ok) return

    const created = await res.json()
    setItems([...items, created])
    setText("")
  }

  async function removeItem(id) {
    const res = await fetch(`/api/items/${id}`, { method: 'DELETE' })
    if (!res.ok) return
    setItems(items.filter(x => x.id !== id))
  }

  return (
    <main style={{ fontFamily: 'system-ui', padding: 24 }}>
    
      <h1>Checky - checklist app</h1>

      <p>{msg} :)</p>
      <p style={{ color: 'green' }}>
        Redis says you've visited this page {hits} times :)
      </p>

      <div style={{ fontFamily: "sans-serif", width: 300, margin: "2rem auto" }}>
        <h2>Todo List</h2>

        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Add item..."
          style={{ width: "100%" }}
        />

        <button onClick={addItem} style={{ marginTop: "0.5rem" }}>
          Add
        </button>

        <ul>
          {items.map((item) => (
            <li key={item.id}>
              {item.name}
              <button
                onClick={() => removeItem(item.id)}
                style={{ marginLeft: "0.5rem" }}
              >
                ✕
              </button>
            </li>
          ))}
        </ul>
      </div>
    </main>
  )
}

export default App
