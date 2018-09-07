---
title: "Contact"
date: "2018-07-01"
layout: "about"
menu: "main"
weight: 60
disqus_enable: false
---

Get in touch!

<div class="basic-form">
  <form action="https://formspree.io/graham+contact@grahamweldon.com" method="POST">
    <div class="row">
      <label>
        <span>Name</span>
        <input type="text" name="name">
      </label>
    </div>
    <div class="row">
      <label>
        <span>Email</span>
        <input type="email" name="_replyto">
      </label>
    </div>
    <div class="row">
      <label>
        <span>Topic</span>
        <select name="topic">
          <option value="Technical">Technical question</option>
          <option value="Game development">Game development</option>
          <option value="Recruitment">Recruitment</option>
          <option value="Other">Other (please specify in message)</option>
        </select>
      </label>
    </div>
    <div class="row">
      <label>
        <span>Message</span>
        <textarea name="message" placeholder="Message" rows="10"></textarea>
      </label>
    </div>
    <div class="row">
      <label>
        <button type="submit">Send</button>
      </label>
    </div>
  </form>
</div>
