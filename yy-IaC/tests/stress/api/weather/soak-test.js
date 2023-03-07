import http from "k6/http";
import { check, sleep } from "k6";

export let options = {
    stages: [
        { duration: "1m", target: 20 }, // Ramp up to 20 virtual users over 1 minute
        { duration: "3m", target: 20 }, // Hold at 20 virtual users for 3 minutes
        { duration: "1m", target: 0 }, // Ramp down to 0 virtual users over 1 minute
    ],
    thresholds: {
        http_req_duration: ["p(95)<500"], // 95% of requests should complete within 500ms
        http_req_failed: ["rate<0.05"], // Error rate should be less than 5%
    },
};

export default function () {
    const url = "http://localhost:8085/api/weather";
    const response = http.get(url);

    check(response, {
        "status is 200": (r) => r.status === 200,
        "response has data": (r) => r.json().length > 0,
    });

    sleep(0.1);
}
