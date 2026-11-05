// Quéleco : dans le cadre du portail, la page de signature dit au portail qu'elle s'est
// affichée. Le portail sait alors que le cadre est permis ; sinon il propose un nouvel
// onglet. Aucun renseignement ne part : seulement { source, etat }.
(function () {
  if (window.parent === window) return;
  try {
    window.parent.postMessage({ source: "queleco-sign", etat: "pret" }, "*");
  } catch (e) {}
})();
