import http from "k6/http";
import { check } from "k6";

export default function () {
  const url = "http://localhost/api/weather";
  const response = http.get(url);

  check(response, {
    "status is 200": (r) => r.status === 200,
    "response has data": (r) => r.json().length > 0,
  });
}
