import os
import torch
import ttnn

torch.manual_seed(0)

device_id = 0
device = ttnn.open_device(device_id=device_id)
device.enable_program_cache()

m = 1024
k = 1024
n = 1024

torch_a = torch.randn((m, k), dtype=torch.bfloat16)
torch_b = torch.randn((k, n), dtype=torch.bfloat16)

a = ttnn.from_torch(torch_a, layout=ttnn.TILE_LAYOUT, device=device)
b = ttnn.from_torch(torch_b, layout=ttnn.TILE_LAYOUT, device=device)

output = a @ b
output = a @ b

print(output.layout)

output = ttnn.to_layout(output, ttnn.ROW_MAJOR_LAYOUT)

print("Printing ttnn tensor")
print(f"shape: {output.shape}")
print(f"chunk of a tensor:\n{output[:1, :32]}")

a = ttnn.from_torch(torch_a)
b = ttnn.from_torch(torch_b)

a = ttnn.to_device(a, device, memory_config=ttnn.L1_MEMORY_CONFIG)
b = ttnn.to_device(b, device, memory_config=ttnn.L1_MEMORY_CONFIG)

a = ttnn.to_layout(a, ttnn.TILE_LAYOUT)
b = ttnn.to_layout(b, ttnn.TILE_LAYOUT)

output = ttnn.matmul(a, b, memory_config=ttnn.L1_MEMORY_CONFIG, core_grid=ttnn.CoreGrid(y=8, x=8))

output = ttnn.matmul(a, b, memory_config=ttnn.L1_MEMORY_CONFIG, core_grid=ttnn.CoreGrid(y=8, x=8))

ttnn.close_device(device)
