return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>sf",
      function()
        Snacks.picker.grep({ regex = false })
      end,
      desc = "Grep (literal/fixed string)",
    },
  },
}
