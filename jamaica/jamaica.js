
const {div, p, a, span, pre, form, label, input, textarea, button, submit, table, thead, tbody, th, tr, td} = van.tags;
const labels={
  nm: "Name",
  desc: "Description",
  pw: "Password",
  addr: "Address",
  eml: "Email",
  max_grp: "Max Group",
  start_addr: "Starting Address",
  dt: "Date",
  tm: "Time",
  ppl: "Number of People"
}

function init() {
  u('a').handle ('click', urlClick)
  u('#login').handle('click',login);
}

function show(target, json) {
  u(target).empty().append(reggae2dom(json));
  u('#main form').on('submit', formSubmit);
  u('a').handle('click', urlClick)
  u('.showRels').handle('click', showRels)
  u('#main > table tbody tr').handle('click', rowClick); //This avoids the behavior for selection tables and also for the header; not sure why the latter is necessary.
}

function req(url, meth, body) {
  if (! meth) {meth="get"}
  return fetch(url, {method: meth, headers: {'Authorization': 'Basic ' + getCreds()}, body: body})
    .then((res) => res.json())
}

function val(name) {
  return u('[name='+name+']').nodes[0].value;
}

function urlClick(e) {
  req(e.target.href)
    .then((json) => show('#main', json))
    .catch((err) => console.error("error:", err));
}

function processResponse(json) {
  if (json[0] == "error") {
    showError(json);
  } else {
    show('#main', json);
  }
}

function formSubmit(e) {
  e.preventDefault();
  req(e.target.action, "POST", u(e.target).serialize()).
    then((json) => processResponse(json)).
    catch((err) => console.error("error:", err));
}
function login(e){
  e.preventDefault();
  fetch('/?nav', { headers: {'Authorization': 'Basic ' + getCreds()}})
    .then((res) => res.text())
    .then((html) => {
      u('#nav').html(html);
      u('#nav a').handle('click', urlClick);
      u('#creds').attr('hidden', 'true');
      u('#creds').after(button({id: "logout"}, "Logout"));
      u('#logout').handle('click',logout)
    })

    .catch((err) => console.error("error:", err));
}

function logout(e){
  location.reload();
  u('#account [name=eml]').nodes[0].value=""; 
  u('#account [name=pw]').nodes[0].value=""; 
}

function getCreds() {
  u('#creds').attr('hidden', 'false');
  return btoa(val('eml') + ":" + val('pw'));
}

function rowClick(e) {
  if (e.target.tagName == 'A') {return}
  var url = "/" + e.target.closest('table').classList[0] + "/" + u(e.target).parent('tr').attr('id');
  req(url)
    .then((json) => show('#main', json))
    .catch((err) => console.error("error:", err));
}

function showRels(e) {
  e.preventDefault();
  e.target.hidden=true;
  var url=e.target.closest('form').action+"/"+e.target.classList[1]+"/options";
  var div_id=e.target.classList[1]+"_list";
  u(e.target).after(div({id:div_id, class:"select"}));
  req(url)
    .then((json) =>{
      show("#"+div_id, json)
      u(e.target.closest('form')).find('span.rel a').each((l) => {u(document.getElementById(l.toString().match(/\d+$/))).addClass('selected')})
    })
    .catch((err) => console.error("error:", err));
}


function showError(json) {
  json.shift();
  for (var e of json) {
    u('[name=' + e[0] + ']').addClass('error').after(span({class: "err_msg"}, e[1]));
  }
}

window.onload=init;

