apiVersion: v1
kind: ConfigMap
metadata:
  name: mission-briefing
  namespace: k8s-ctf
  labels:
    challenge: "01"
data:
  briefing.txt: |
    Welcome agent.
    Your first flag is hidden in plain sight.
    __FLAG_01__
  decoy.txt: |
    K8SCTF{repo_grep_is_not_a_valid_solution}
    K8SCTF{this_is_only_bait}
