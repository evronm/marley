
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
    if (typeof(eid)=="number"){
      var url="/" + eid;
    } else {
      var url="/" + typ + "/" + eid;
    }
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
    return a({href: json[0], id: "link_" + json[0].replace(/.*\//,"")}, json[1]);
  }
}

u.prototype.eid=function() { 
  return u(this).attr('id').match(/\d+$/)[0] 
}

function Field (spec, val) {
  this.name=spec[0];
  this.type=spec[1].replace('bool', 'checkbox'); //yes, facepalm :/
  this.restrictions=spec[2];
  this.val=val ? val : "";
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
  if (this.restrictions.indexOf("ro")>-1) {
    return [this.label(), reggae2dom(this.val)]
  } else {
    return [this.label(), reggae2dom(this.val).map((u) => span({class: "rel"}, u)), button({class: "showRels " + this.name}, "✎")]
  }
}

function Table(json) {
  this.typ=json[0][0];
  this.sel_type=json[0][1];
  this.flags=json[0][2];
  this.spec=json[0][3];
  this.data=json[1];
}
Table.prototype.dom=function() {
  var data=table( {class: this.typ + " " + this.sel_type},
    thead(tr( this.spec.map ((s) => th({class: s[1]}, s[0]) ))),
    tbody(this.data ? this.data.map((r) => tr({"id": "row_" + r.shift()}, r.map((f) => td(reggae2dom (f))))) : ""));
  var new_url="/"+this.typ+"/new";
  if (this.type.includes("new")) {
    return div(new_url, data)
  } else {
    return data;
  }
}
