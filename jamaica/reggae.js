
function reggae2dom(json) {
  if (typeof(json)=="object") {
    if (typeof(json[0])=="string") {
      return (Reggae[json.shift()](json));
    } else {
      return json.map((m) => reggae2dom(m));
    }
  } else {
    return json
  }
}

const Reggae={
  instance: (json) => {
    var typ=json[0][0];
    var eid=json[0][1];
    var url="/" + typ + "/" + eid;
    var flags=json[0][2];
    var vals=json[1] || [];
    var srch=false;  //change to implement search
    var method= (srch ? "get" : "post");
    var fields=json[0][3].map((s,i) => {return new Field(s, vals[i+1]).dom()});
    if (flags=="ro"){
      return div({class:"ro", id:url}, fields);
    } else {
      return form({action: url, method: method}, fields, input({type:"submit", value: (srch ? "Search" : "Save")}));
    }

  },
  instances: (json) => {return new Table(json).dom()},
  mesg: (title, content) => {
    return "asdf";
  },
  url: (json) => {
    return a({href: json[0]}, json[1]);
  }
}


function Field (spec, val) {
  this.name=spec[0];
  this.type=spec[1].replace('bool', 'checkbox'); //yes, facepalm :/
  this.restrictions=spec[2];
  this.val=val;
}

Field.prototype.dom=function() {
  if (this.restrictions.indexOf("ro")>-1) {
    return this.ro();
  }
  if (this[this.type]){
    return this[this.type]();
  } else {
    return this.default();
  }
}

Field.prototype.label=function() {
  return label({for: this.name}, (labels[this.name] ? labels[this.name] : this.name) + ":");
}

Field.prototype.default=function() {
  return [this.label(), input({type: this.type, name: this.name, value: this.val})];
}
Field.prototype.password=function() {
  return [this.default(), [label({for: "confirmpw"}, "Confirm Password:"), input({type: this.type, name: "confirmpw"})]];
}

Field.prototype.ro=function() {
  return [this.label(), span({class: "ro"}, reggae2dom(this.val))];
}

Field.prototype.instances=function() {
  return [this.label(), reggae2dom(this.val), button({class: "showRels " + this.name}, "+")]
}

function Table(json) {
  this.typ=json[0][0];
  this.flags=json[0][2];
  this.spec=json[0][3];
  this.data=json[1];
}
Table.prototype.dom=function() {
  return table( {class: this.typ},
    thead(tr( this.spec.map ((s) => th({class: s[1]}, s[0]) ))),
    tbody(this.data.map((r) => tr({"eid": r.shift()}, r.map((f) => td(reggae2dom (f)))))));
}
