
const {div, p, pre, form, input, textarea, button, submit} = van.tags
window.onload=() => {
  u('a').handle ('click', (e) => {
    fetch(new Request(e.target.href)).then((resp) => {u('#main').html(resp);})
  })
}
