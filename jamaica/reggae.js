
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
  instances: (json) => {
    var typ=json[0][0];
    var flags=json[0][1];
    var spec=json[0][3];
    var data=json[1];
    return VanTable(spec.map((s) => s), data.map((d) => reggae2dom(d)), {class: "display"});
  },
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
  this.type=spec[1].replace('bool', 'checkbox'); //I hate this, but it's needed
  this.restrictions={};
  if (spec[2]) {
    this.restrictions.ro=spec[2].includes("ro");
    this.restrictions.required=spec[2].includes("required");
    ["min", "max", "options"].forEach((r) => this.restrictions[r]=spec[2].find((restr) => restr[0]==r))
  }
  this.val=val ? val : "";
}

Field.prototype.dom=function() {
  if (this.restrictions.ro) {
    return this.ro();
  }
  if (Fields[this.name]){
    return Fields[this.name](this);
  } else if (this[this.type]){
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
  return VanTable(this.restrictions.options[1], this.restrictions.options[2],{select:"multi", field_name: this.name, selected: this.val})
}

function VanTable (cols, data, conf) {
  if (conf.select){ var selector=conf.select == "one" ? "radio" : "checkbox"}

  return table({class: conf.class, id: conf.id}, 
    thead(
      ((conf.select ? [""] : []).concat(cols)).map((col) => th({class: col[0]}, labels[col[0]] ? labels[col[0]] : col[0]))
    ),
    tbody(
      conf.select ? 
        data.map((row) => {var id=row.shift();return tr(td(input({type: selector, name: conf.field_name, value: id, checked: (conf.selected && conf.selected.includes(id))})), row.map((cell) => td(cell)))})
      : 
        data.map((row) => tr({id: row.shift()}, row.map((cell) => td(cell))))
    )
  );
}
