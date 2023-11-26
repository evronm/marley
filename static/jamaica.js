
const NEW=1;
const SRCH=2;

const {div, p, span, pre, form, label, input, textarea, button, submit} = van.tags;
function init() {
  u('#account_nav a').handle ('click', navclick)
}


function navclick(e) {
  fetch(e.target.href)
    .then((res) => res.json())
    .then((json) => show('#main', json))
    .catch((err) => console.error("error:", err));
}

function show(target, json) {
  u(target).empty().append(Reggae[json[0]](json));
  u('form').on('submit', formSubmit);
}

function processResponse(json) {
  if (json[0] == "error") {
    showError(json);
  } else {
    show('#main', json);
  }
}

function showError(json) {
  json.shift();
  for (var e of json) {
    u('[name=' + e[0] + ']').addClass('error').after(span({class: "err_msg"}, e[1]));
  }
}

function formSubmit(e) {
  e.preventDefault();
  fetch(e.target.action, {method: "POST", body: u(e.target).serialize()}).
    then((res) => res.json()).
    then((json) => processResponse(json)).
    catch((err) => console.error("error:", err));
}

const Reggae={
  instance: (json) => {
    var spec=json[1];
    var newrec=spec[0] & NEW;
    var srch=spec[0] & SRCH;
    var url=spec[1]
    var method="post";
    var fields=spec[2].map((s) => {return new Field(s).dom()});
    return form({action: url, method: method}, fields, input({type:"submit", value: "Save"}));

  },
  mesg: (title, content) => {
    return "asdf";
  }
}


function Field (spec) {
  this.name=spec[0];
  this.type=spec[1].replace('bool', 'checkbox'); //yes, facepalm :/
  this.restrictions=spec[2];
}

Field.prototype.dom=function() {
  if (this[this.type]){
    return this[this.type]();
  } else {
    return this.default();
  }
}

Field.prototype.default=function() {
  return [label({for: this.name}, labels[this.name] + ":"), input({type: this.type, name: this.name})]
}
Field.prototype.password=function() {
  return [this.default(), [label({for: "confirmpw"}, "Confirm Password:"), input({type: this.type, name: "confirmpw"})]];
}




