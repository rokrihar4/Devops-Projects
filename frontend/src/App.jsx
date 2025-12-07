import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [msg, setMsg] = useState('…loading…')
  const [demos, setDemo] = useState([])
  const [hits, setHits] = useState(null)
  const [items, setItems] = useState([])
  const [text, setText] = useState("")   // <-- added this

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

  function addItem() {
    if (!text.trim()) return // ignore empty entries
    setItems([...items, text])
    setText("")
  }

  function removeItem(index) {
    setItems(items.filter((_, i) => i !== index))
  }

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
          {items.map((item, i) => (
            <li key={i}>
              {item}
              <button
                onClick={() => removeItem(i)}
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
