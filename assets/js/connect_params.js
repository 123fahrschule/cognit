function getCookie(name) {
  const cookies = document.cookie.split("; ");
  const cookie = cookies.find((c) => c.startsWith(`${name}=`));
  return cookie ? cookie.split("=")[1] : null;
}

export function getCognitParams() {
  return {
    sidebar_state: getCookie("sidebar_state") || "expanded",
  };
}
